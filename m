From: Niranjan <niranjan_cs2905@yahoo.com>
Subject: Re: kernel bug at sched.c:564! + linux kernel 2.4.25
Date: Wed, 28 Jul 2004 09:30:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040728163029.55069.qmail@web53001.mail.yahoo.com>
References: <Xine.LNX.4.44.0407281210270.11261-100000@dhcp83-76.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladimir Kondratiev <vkondra@mail.ru>, Matt Mackall <mpm@selenic.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0407281210270.11261-100000@dhcp83-76.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The driver code is in kernel loadable module. The
linux-wlan-ng driver for the linux wireless cards has
two kernel loadable modules - prism2_cs and p80211.
I included the encrypt() and decrypt() function of
cryptoapi inside the p80211.o kernel module instead of
using cipher-<cipher_name>.o module for encryption and
decryption. The cipher context (cipher name and cipher
mode) and key (key length and cipher key) is still set
through cryptoapi.o module.

Warm Regards,
-Niranjan

--- James Morris <jmorris@redhat.com> wrote:

> On Wed, 28 Jul 2004, Niranjan wrote:
> 
> > Hi,
> > I got the code working by including the encrypt()
> and
> > decrypt() function inside the WLAN driver. 
> > Is there any better way to get the CrytoAPI code
> > working from the driver or some other CryptoAPI
> > implementation ?
> 
> Where is the driver code?
> 
> 
> - James
> -- 
> James Morris
> <jmorris@redhat.com>
> 
> 
> 
> 



		
__________________________________
Do you Yahoo!?
Yahoo! Mail - 50x more storage than other providers!
http://promotions.yahoo.com/new_mail
