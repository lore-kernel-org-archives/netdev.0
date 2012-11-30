From: Alan Ott <alan@signal11.us>
Subject: Re: [PATCH] 6lowpan: consider checksum bytes in fragmentation threshold
Date: Thu, 29 Nov 2012 20:58:37 -0500
Message-ID: <50B812CD.5000802@signal11.us>
References: <504EA95C.9010003@signal11.us> <1354240544-22214-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Ott <alan@signal11.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354240544-22214-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/29/2012 08:55 PM, Alan Ott wrote:
> Change the threshold for framentation of a lowpan packet from
> using the MTU size to now use the MTU size minus the checksum length,
> which is added by the hardware. For IEEE 802.15.4, this effectively
> changes it from 127 bytes to 125 bytes.
>

Sorry, this was put in the wrong thread. One day I'll get one of these
first-try. :(
