From: James Morris <jmorris@redhat.com>
Subject: Re: ipsec (ipv4 tunnel mode) is broken
Date: Mon, 7 Feb 2005 14:30:35 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0502071430130.28475-100000@thoron.boston.redhat.com>
References: <Pine.LNX.4.58.0502071320400.12462@lacrosse.corp.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
To: Matthew Galgoci <mgalgoci@redhat.com>
In-Reply-To: <Pine.LNX.4.58.0502071320400.12462@lacrosse.corp.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Feb 2005, Matthew Galgoci wrote:

> 
> I noticed as recenly as 2.6.11-rc3-bk3 that ipv4 ipsec is broken. I'm currently using
> openswan as my ike daemon. This was working with the same ike daemon and config as 
> (I think) recenrly as 2.6.11-rc2.
> 
> Before I go binary searching for the change that broke it, I was wondering if anyone
> knows offhand what the issue might be from these error messages in my kernel log:
> 
> NET: Registered protocol family 15
> ESP: md5 digestsize 16 != 0
> ESP: md5 digestsize 16 != 0
> ESP: md5 digestsize 16 != 0
> ESP: md5 digestsize 16 != 0
> 
> openswan dies somewhere between phase 1 and phase 2 negotiation with an internal error.

This patch should fix it (now in bk iirc):

http://marc.theaimsgroup.com/?l=linux-netdev&m=110746335402355&w=2


- James
-- 
James Morris
<jmorris@redhat.com>
