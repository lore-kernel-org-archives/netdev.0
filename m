From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net/r8169: Correct the ram code for RTL8111D(L)
Date: Fri, 26 Nov 2010 23:49:14 +0100
Message-ID: <20101126224914.GA12266@electric-eye.fr.zoreil.com>
References: <1290772470-23713-1-git-send-email-hayeswang@realtek.com>
 <1290779458.3051.45.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	564628@bugs.debian.org
To: Ben Hutchings <benh@debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1290779458.3051.45.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings <benh@debian.org> :
> On Fri, 2010-11-26 at 19:54 +0800, Hayes Wang wrote:
> > Correct the binary code (Low pass filter & DLY_CAP fine tune from uC).
> > The incorrect ram code would make the nic working abnormally.
> [...]
> 
> I'm glad you finally acknowledge that this is code rather than simple
> register initialisation.

I am not sure that Hayes is a native english speaker.

I am glad to see him posting here.

[...]
> Below are the changes Debian currently applies in preparation for proper
> licencing of the firmware.

Do you have some scripts to convert the data at hand ?

I would welcome a clear statement regarding the status of the binary thing
(code ? data ?) but even without one *now*, I'd like to see it separated
from the main code : the driver sucks and things will go worse with
support code for the 8168e.

Is there anybody objecting to it ? I will buy anything be it firmware API
or plain .h.

-- 
Ueimor
