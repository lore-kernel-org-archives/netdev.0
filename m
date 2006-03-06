From: David Stevens <dlstevens@us.ibm.com>
Subject: RE: RFC: move SDP from AF_INET_SDP to IPPROTO_SDP
Date: Mon, 6 Mar 2006 12:31:33 -0800
Message-ID: <OF8F668698.3BC5B375-ON88257129.00701FC1-88257129.007069DF@us.ibm.com>
References: <54AD0F12E08D1541B826BE97C98F99F12FBF33@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@mellanox.co.il>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751625AbWCFU15@vger.kernel.org>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F12FBF33@NT-SJCA-0751.brcm.ad.broadcom.com>
To: "Caitlin Bestler" <caitlinb@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPPROTO_* should match the protocol field on the wire, which
I gather isn't different. And I'm assuming there is no standard API
defined already...

What about using a socket option?

                                        +-DLS
