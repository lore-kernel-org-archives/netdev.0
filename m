From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: ieee80211 patches
Date: Thu, 25 Aug 2005 20:49:52 -0400
Message-ID: <200508252049.52413.flamingice@sourmilk.net>
References: <20050825193112.529d0dc9@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, NetDev <netdev@vger.kernel.org>,
        Jeff Garzik <jgarzik@pobox.com>, jbohac@suse.cz, pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050825193112.529d0dc9@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 25 August 2005 13:31, Jiri Benc wrote:
> Our patches against latest ieee80211 branch can be found at
> http://kernel.org/pub/linux/kernel/people/jbenc/
>
I hope to submit the adm8211 driver for review soon, but there's a bunch of 
code in the driver which probably belong in the ieee80211 code:

- Duplicate frame removal
- Definitions for all management payloads
- SIOCSIWENCODEEXT and SIOCGIWENCODEEXT
- AVS capture header in monitor mode
- Software Scanning
- Software Authentication & Association

Does that sound okay? I will start submitting patches to add those things if 
they should be in the ieee80211 code.

Thanks,
-Michael Wu
