From: "David S. Miller" <davem@redhat.com>
Subject: Re: MAC-VLANS
Date: Tue, 5 Aug 2003 20:40:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030805204028.644895dc.davem@redhat.com>
References: <3F304CBF.6050902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F304CBF.6050902@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 05 Aug 2003 17:33:03 -0700
Ben Greear <greearb@candelatech.com> wrote:

> In order to get MAC-VLANs to work, the only way I can see to make
> it happen is to put a hook into dev.c in the:

Why not do it the same we do normal VLAN's?  Ie. directly
in the device driver receive method via something akin to
the vlan_hwaccel_*() routines.
