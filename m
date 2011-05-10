From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 0/7] Network namespace manipulation with file descriptors
Date: Tue, 10 May 2011 14:56:25 -0700
Message-ID: <987664A83D2D224EAE907B061CE93D5301CCC622F4@orsmsx505.amr.corp.intel.com>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<20110509.120408.48494155.davem@davemloft.net>
	<m1oc3btzk4.fsf@fess.ebiederm.org>
 <20110509.134007.116389415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"daniel.lezcano@free.fr" <daniel.lezcano@free.fr>,
	"containers@lists.osdl.org" <containers@lists.osdl.org>,
	"renatowestphal@gmail.com" <renatowestphal@gmail.com>
To: David Miller <davem@davemloft.net>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20110509.134007.116389415.davem@davemloft.net>
Content-Language: en-US
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> The conflicts on syscall syscall numbers are an unfortunate pain.
>
> The way we've solved this before is the tree that cares pulls in
> the net-next-2.6 tree to resolve the conflict.

Actually it seems more common that new syscalls are only added to
x86 (plus one or more other architectures that the author cares
about). Then arch maintainers throw in a "wire up new syscalls"
patch during the merge window when they see these new bits show up.

-Tony

Oh - ia64 wiring looks good.

Acked-by: Tony Luck <tony.luck@intel.com>
