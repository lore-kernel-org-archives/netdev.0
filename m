From: Frank Pavlic <PAVLIC@de.ibm.com>
Subject: Re: FWD:  setting skb->dev to vlan device in vlan_hwaccel_rx is wrong ...
Date: Wed, 20 Oct 2004 10:08:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFB8B932F8.E041070C-ONC1256F33.0027CE30-C1256F33.002CBE1E@de.ibm.com>
References: <20041019233618.6fdcb01d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com, vlan@candelatech.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20041019233618.6fdcb01d.davem@redhat.com>
To: Ben Greear <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 oh , I'm sorry for confusing you guys , I finally get the point on how 
the 
hw_accel_rx stuff is working ...

Frank




"David S. Miller" <davem@redhat.com> 
20.10.2004 08:36

To
Ben Greear <greearb@candelatech.com>
cc
vlan@candelatech.com, Frank Pavlic/Germany/IBM@IBMDE, netdev@oss.sgi.com
Subject
Re: FWD:  setting skb->dev to vlan device in vlan_hwaccel_rx is wrong ...






On Fri, 15 Oct 2004 16:27:46 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Dave, since you did the hw-accel work, what do you think of this patch?

I see no mention of what specific part of the "receive path"
depends upon the skb->dev being set to the real_dev and not
the true VLAN device.
