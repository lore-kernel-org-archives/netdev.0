From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [Patch net-next v3 9/9] selinux: use generic union inet_addr
Date: Tue, 20 Aug 2013 07:28:15 -0700
Message-ID: <52137CFF.70601@schaufler-ca.com>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>  <1376907278-26377-10-git-send-email-amwang@redhat.com>  <52127336.3080209@schaufler-ca.com>  <20130819.125026.636442915180863272.davem@davemloft.net>  <5212915F.20905@schaufler-ca.com> <1377003677.13412.5.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	james.l.morris@oracle.com, sds@tycho.nsa.gov,
	eparis@parisplace.org, pmoore@redhat.com,
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377003677.13412.5.camel@cr0>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/20/2013 6:01 AM, Cong Wang wrote:
> On Mon, 2013-08-19 at 14:42 -0700, Casey Schaufler wrote:
>> Well, they certainly don't appear to add any value on their own.
>> I also generally oppose doing clever things with data structures. 
> If you want to implement same thing for 5+ times,

Those 5+ implementations are already there, and already work.
A 6th implementation to replace known working code is just churn
unless it provides some additional value. Making the code "better"
does not itself add value. 

>  yes, it has no value
> for you. Enjoy the following code in current tree:
>
> union nf_inet_addr;
> union sctp_addr;
> union vxlan_addr; (in my VXLAN IPv6 patches, search email archives)
> struct br_mdb_entry::addr;
> union inet_addr; (in netpoll.h)
>
> And may I tell you the last three are all from me? ;-)

I do use and enjoy all of these implementations! Thank you
for the fine implementations. In the end, if you're maintaining
the code it's your call. I question change that does not have
an obvious purpose because statistically every 10th change has
a bug.

Now that I know what the change is for I am fine with it. I
like seeing reasons up front.

>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
