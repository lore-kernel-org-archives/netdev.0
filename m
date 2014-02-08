From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: REGRESSION f54b311142a92ea2e42598e347b84e1655caf8e3 tcp auto
 corking slows down iSCSI file system creation by factor of 70 [WAS: 4 TB
 VMFS creation takes 15 minutes vs 26 seconds]
Date: Sat, 8 Feb 2014 17:57:32 +0100
Message-ID: <20140208165732.GB22359@glanzmann.de>
References: <20140207205142.GA8609@glanzmann.de>
 <20140208093808.GD16336@glanzmann.de>
 <1391865273.10160.76.camel@edumazet-glaptop2.roam.corp.google.com>
 <1391866389.10160.80.camel@edumazet-glaptop2.roam.corp.google.com>
 <1391867404.10160.88.camel@edumazet-glaptop2.roam.corp.google.com>
 <1391868816.10160.93.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208141905.GG20512@glanzmann.de>
 <1391869805.10160.97.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208150001.GI20512@glanzmann.de>
 <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Eric,

> Note : We did some patches in the MSG_MORE logic for sendpage(), but
> in your case I do not think its related
> (git grep -n MSG_SENDPAGE_NOTLAST ) if you are curious

thank you for the pointer. The iSCSI target code actually uses sendpage
whenever it can.

Cheers,
        Thomas
