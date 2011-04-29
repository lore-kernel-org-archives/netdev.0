From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] wireless: Make struct ieee80211_channel const
 where possible
Date: Fri, 29 Apr 2011 09:11:38 +0200
Message-ID: <1304061098.3589.0.camel@jlt3.sipsolutions.net>
References: <cover.1304054543.git.joe@perches.com>
	 <b953f08a496209fe0fb69166c5175ff270b7efc5.1304054543.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b953f08a496209fe0fb69166c5175ff270b7efc5.1304054543.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-04-28 at 22:25 -0700, Joe Perches wrote:
> Useful for declarations of static const.

I don't mind marking lots of places const, but it isn't actually as
useful as you think since you can't declare any channels const as they
are modified at runtime for regulatory enforcement.

johannes
