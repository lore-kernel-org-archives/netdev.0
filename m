From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/1 net-next] mac80211: remove unnecessary null test
 before debugfs_remove
Date: Tue, 21 Oct 2014 21:06:06 +0200
Message-ID: <1413918366.1998.10.camel@jlt4.sipsolutions.net>
References: <1413908412-5177-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413908412-5177-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-10-21 at 18:20 +0200, Fabian Frederick wrote:
> Fix checkpatch warnings:
> 
>     WARNING: debugfs_remove(NULL) is safe this check is probably not required

I'll apply this; however, I think that checkpatch is a just tool, and
the commit message should reflect why you're changing the code.
Presumably you're not doing it to make the tool happy, but to address an
issue that the tool pointed out, so I think in most cases the commit
message should state the former, not the latter.

Note that in this particular case the NULL check check could be there to
avoid a memory write (which can be significant depending on the context)
so blindly doing what the tool suggested wouldn't always be a good idea.

johannes
