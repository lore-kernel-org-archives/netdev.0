From: "David S. Miller" <davem@redhat.com>
Subject: Re: FWD:  setting skb->dev to vlan device in vlan_hwaccel_rx is
 wrong ...
Date: Tue, 19 Oct 2004 23:36:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019233618.6fdcb01d.davem@redhat.com>
References: <OF1AA93F13.5E509602-ONC1256F2E.00506148-C1256F2E.00551602@de.ibm.com>
	<41705CF2.9050303@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vlan@candelatech.com, pavlic@de.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <41705CF2.9050303@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Oct 2004 16:27:46 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Dave, since you did the hw-accel work, what do you think of this patch?

I see no mention of what specific part of the "receive path"
depends upon the skb->dev being set to the real_dev and not
the true VLAN device.
