From: Alessandro Suardi <alessandro.suardi@oracle.com>
Subject: Re: analysis of TCP window size issues still around - several reports
 / SACK involved?
Date: Wed, 07 Jul 2004 23:25:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40EC6A52.70207@oracle.com>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org> <20040629222751.392f0a82.davem@redhat.com> <20040630152750.2d01ca51@dell_ss3.pdx.osdl.net> <20040630153049.3ca25b76.davem@redhat.com> <20040701133738.301b9e46@dell_ss3.pdx.osdl.net> <20040701140406.62dfbc2a.davem@redhat.com> <20040702013225.GA24707@conectiva.com.br> <20040706093503.GA8147@outpost.ds9a.nl> <20040706131955.3a3c6c8b.davem@redhat.com> <20040706202708.GA1385@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, acme@conectiva.com.br,
        shemminger@osdl.org, netdev@oss.sgi.com, phyprabab@yahoo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20040706202708.GA1385@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert wrote:
> On Tue, Jul 06, 2004 at 01:19:55PM -0700, David S. Miller wrote:
> 
> 
>>rather it do this, so that diagnosing dumps are easier.  If tcpdump
>>tries to be too clever, scaling the window, then I might end up
>>chasing down a tcpdump bug rather than a TCP one :-)
> 
> 
> True - it might want to print '43 (*128=5706)' or something like that.
> 
> 
>>What would be more interesting is to get the tcpdump trace from the
>>other side of this connection.  This is crucial, as it will show how
>>and in what way exactly the window scale options and/or window fields
>>are being edited by a firewall or other device and thus causing
>>the problems.
> 
> 
> I have an appointment with Alessandro tomorrow evening at 11PM CEST to do
> just that.

Sorry about being slightly late - I read the thread from my VPN
  link (which does work), now I'm turning it off and will email
  Bert with my actual IP address and my connection.

Thanks,

--alessandro

  "Practice is more important than theory. A _lot_ more important."
     (Linus Torvalds on lkml, 1 June 2004)
