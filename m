From: "Weber Matthias" <weber@faps.uni-erlangen.de>
Subject: Resending ethernet packets to direct neighbours
Date: Mon, 14 Mar 2005 11:38:48 +0100
Message-ID: <09766A6E64A068419B362367800D50C0B58A65@moritz.faps.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

i have a pc with five ethernet devices onto and want to resend ethernet packets coming in from one device to four direct neighbours (distance 1). Therefore i have installed a packet handler receiving skbs. 
Now i have the following questions: 
1) is it enough to change the skb->dev to the output device, rebuild the ethernet header and call dev_queue_xmit()?
2) how to i get the destination ethernet address of the physically direct neighbour within the packet handler? I believe, that i have to use the neighour caches but have not idea how...

Any help would be appreciated!


Bye
Matthias


