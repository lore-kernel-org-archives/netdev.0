From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211_hwsim: missing NULL check
Date: Wed, 02 Dec 2015 10:51:58 +0100
Message-ID: <1449049918.2449.6.camel@sipsolutions.net>
References: <1448867812-11089-1-git-send-email-rahul.jain@samsung.com>
	 (sfid-20151130_081822_747132_014FEC1F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Amit Khatri <amit.khatri@samsung.com>
To: Rahul Jain <rahul.jain@samsung.com>, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448867812-11089-1-git-send-email-rahul.jain@samsung.com> (sfid-20151130_081822_747132_014FEC1F)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-30 at 12:46 +0530, Rahul Jain wrote:
> From: Amit Khatri <amit.khatri@samsung.com>
> 
> txrate variable might be NULL and passing inside function
> without NULL check.

Applied. However, this comes with a big BUT.

I seems to always be rewriting your static checker patches, or asking
for clarification, rewording, etc.

Please: review what I did to this commit, and in the future please
submit patches that actually describe what's going on, what you're
doing, and why you're doing it.

IOW, analyse the code and don't just do the minimum necessary to shut
up the static checker. Doing that is fairly much useless, especially in
really obscure cases like this.

I'm going to drop further patches like this one without warning.

johannes
