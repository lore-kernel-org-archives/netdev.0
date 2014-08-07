From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtl8150: Check if RSR is already defined
Date: Wed, 06 Aug 2014 22:36:11 -0700 (PDT)
Message-ID: <20140806.223611.1134627526934618200.davem@davemloft.net>
References: <1407389095-31426-1-git-send-email-xerofoiify@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: petkan@nucleusys.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xerofoiify@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407389095-31426-1-git-send-email-xerofoiify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick Krause <xerofoiify@gmail.com>
Date: Thu,  7 Aug 2014 07:24:54 +0200

> I am getting the following warn
> 
> drivers/net/usb/rtl8150.c:30:0: warning: "RSR" redefined
> arch/xtensa/include/asm/processor.h:189:0: note: this is the location of the previous definition
> 
> I wanted to remove RSR as it is not being used but it is not clear if being used
> for documenting purpose. undefining should be enough.
> 
> Signed-off-by: Nick Krause <xerofoify@gmail.com>

This isn't the right way to fix this.

Rather, the thing to do is to give the macros in this driver an
appropriate prefix such as "RTL8150_" so that they don't collide
with things in the global namespace.
