From: "Dr. Peter Bieringer" <pb@bieringer.de>
Subject: Re: 2.5.70-bk9: no IPsec modules are autoloaded
Date: Thu, 05 Jun 2003 14:26:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <34470000.1054816007@klopffest.muc.aerasec.de>
References: <29980000.1054812100@klopffest.muc.aerasec.de>
 <20030605.051238.74748591.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030605.051238.74748591.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Thursday, June 05, 2003 05:12:38 AM -0700 "David S. Miller" 
<davem@redhat.com> wrote:

>    From: "Dr. Peter Bieringer" <pb@bieringer.de>
>    Date: Thu, 05 Jun 2003 13:21:40 +0200
>
>    Sure known that autoloading of IPsec modules is broken...is this a bug
> or     by design?
>
> You (or someone) has to add the appropriate entries to
> /etc/modules.conf

Ok, good to know.

Are there any aliases possible like

alias-something-ike af_key
alias-something-cryptobasic-49 ah
alias-something-cryptobasic-50 esp
alias-something-crypto-modules-0 crypt_null

pre-install esp modprobe ah


BTW: isn't this file called now "modprobe. conf"?

Thanks,
	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
