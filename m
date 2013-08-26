From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 0/8] bonding: remove vlan special handling
Date: Mon, 26 Aug 2013 22:33:47 +0200
Message-ID: <20130826203347.GA26371@redhat.com>
References: <1377534533-6944-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739Ab3HZUfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 16:35:06 -0400
Content-Disposition: inline
In-Reply-To: <1377534533-6944-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 26, 2013 at 06:28:45PM +0200, Veaceslav Falico wrote:
>The aim of this patchset is to remove bondings' own vlan handling as much
>as possible and replace it with the netdev upper device functionality.
>
>This is achieved by exporting the netdev_upper structure and thus permiting
>bonding to work directly with its upper devices. The only non-bonding
>change is the exporting of netdev_upper, and the only special treatment of
>vlans left is in the rlb mode.
>
>This patchset solves several issues with bonding, simplifies it overall,
>RCUify further and exports netdev_upper for any other users which might
>also want to get rid of its own vlan_lists.
>
>I'm testing it continuously currently, no issues found, will update on
>anything.

Self-NAK on the whole series, changed the upper device management approach,
as suggested by Jiri, and sent the new version.
