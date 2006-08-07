From: moto@arba.com
Subject: Reboot-Shutdown signal through net device.
Date: Mon, 07 Aug 2006 13:49:22 -0700
Message-ID: <20060807134922.eaa6a190c7abddfed9ba5ffb54cc233d.2f0ff9250f.wbe@email.secureserver.net>
Mime-Version: 1.0
Content-Type: TEXT/plain; CHARSET=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout12-02.prod.mesa1.secureserver.net ([68.178.232.4]:39316
	"HELO smtpout12-02.prod.mesa1.secureserver.net") by vger.kernel.org
	with SMTP id S932353AbWHGUtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 16:49:23 -0400
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Within our PCI Network Device there is a special feature, that allows
out-of-band signaling-messeging (by using special interrupt and shared
registers) to control system state: Reboot, Shutdown.
What would be an acceptable method of executing such controls?
So, the sequence is: 
     1. Device Driver receives Reboot-or-Shutdown message.
     2. Device Driver initiates Reboot-or-Shutdown sequence (how?).
I have cosidere usermode helper, looks like this solution is favored...
Any recommendations?

