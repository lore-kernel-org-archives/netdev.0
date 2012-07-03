From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH 00/13] drivers: hv: kvp
Date: Tue, 3 Jul 2012 15:20:49 +0200
Message-ID: <20120703132049.GA10663@aepfle.de>
References: <20120621224737.GA5933@kroah.com>
 <426367E2313C2449837CD2DE46E7EAF9155EC47A@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20120622132547.GA2639@kroah.com>
 <426367E2313C2449837CD2DE46E7EAF9155ED14D@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20120626213954.GA4840@kroah.com>
 <426367E2313C2449837CD2DE46E7EAF9155ED64A@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20120626222205.GA5948@kroah.com>
 <426367E2313C2449837CD2DE46E7EAF9155ED68D@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20120628142340.GA21537@aepfle.de>
 <426367E2313C2449837CD2DE46E7EAF9155EF399@SN2PRD0310MB382.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Greg KH <gregkh@linuxfoundation.org>, apw@canonical.com,
	devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: KY Srinivasan <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <426367E2313C2449837CD2DE46E7EAF9155EF399@SN2PRD0310MB382.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, KY Srinivasan wrote:

> While I toyed with your proposal, I feel it just pushes the problem
> out of the daemon code - we would still need to write distro specific
> scripts. If this approach is something that everybody is comfortable
> with, I can take a stab at implementing that. 

Until NetworkManager is feature complete and until every distro is using
NetworkManager per default the kvp_daemon needs distro specific code to
get and set network related settings.
Doing it with an external script will simplify debugging and changes to
the code.

Olaf
