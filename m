From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [RFC][PATCH] Very basic sysfs support for ATM devices (updated)
Date: Fri, 04 Feb 2005 13:50:16 -0500
Message-ID: <200502041850.j14IoFU0021526@ginger.cmf.nrl.navy.mil>
References: <castet.matthieu@free.fr>
Cc: netdev@oss.sgi.com, linux-atm-general@lists.sourceforge.net,
        usbatm@lists.infradead.org
To: matthieu castet <castet.matthieu@free.fr>
In-Reply-To: Message from matthieu castet <castet.matthieu@free.fr>
   of "Fri, 04 Feb 2005 19:27:07 +0100." <4203BE7B.2030503@free.fr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <4203BE7B.2030503@free.fr>,matthieu castet writes:
>Shouldn't adev->signal == ATM_PHY_SIG_FOUND ? 1 : 0); be better : in the 
>case of ATM_PHY_SIG_UNKNOWN, it return 1...

its intentional.  if the atm device cant track the state of the link
its probably best to just assume its up.
