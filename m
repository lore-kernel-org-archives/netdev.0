From: jamal <hadi@cyberus.ca>
Subject: Re: [RTNETLINK] Provide real oif
Date: 02 Dec 2003 19:08:17 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1070410097.1038.27.camel@jzny.localdomain>
References: <E1ARHXF-0007cM-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1ARHXF-0007cM-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-12-02 at 15:54, Herbert Xu wrote:
> jamal <hadi@cyberus.ca> wrote:
> > 
> > Can you provide a real example (output of route display in user space)
> > where this would be valuable?
> 
> Without the real oif you will see entries like this in the output of
> ip r l c:
> 
> 192.168.0.7 dev eth0  src 192.168.0.6
>     cache  mtu 1500 advmss 1460 metric10 64
> 192.168.0.7 dev eth0  src 192.168.0.6
>     cache  mtu 1500 advmss 1460 metric10 64
> 
> One of those has oif == 0 while the other one has oif == eth0.
> 

They both seem to have an oif of eth0, no? 

> To generate an entry with oif == eth0, just send a UDP packet and
> bound to eth0.

Sorry, i am a bit slow - i think i may know where you are going with
this but help me out; 
By binding to eth0, you mean socket bind() or msg_dontroute of the udp
packet via eth0?
Is it unicast? Do you have a small sample proggie i could use to check
this?

> > whats wrong with the combo of RTA_OIF and RTA_SRC?
> 
> Both of those attributes are independent of the real oif.
 
They are related in the rt selection.
If you have a small program i can use to create the above cacheinfo
i would appreaciate it. Is the same IP attached to multiple interfaces
that you need to select a prefered OIF?  

cheers,
jamal
