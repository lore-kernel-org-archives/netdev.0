From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net:wireless - Change 1 to true for bool type variable.
Date: Mon, 25 May 2015 11:11:16 -0700
Message-ID: <1432577476.2846.68.camel@perches.com>
References: <1432576544-3639-1-git-send-email-shailendra.capricorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shailendra Verma <shailendra.capricorn@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432576544-3639-1-git-send-email-shailendra.capricorn@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-05-25 at 23:25 +0530, Shailendra Verma wrote:
> The variable translate is bool type.So assigning true instead of 1.

There are a lot these in the kernel.

$ git grep -P "^[ \t]*(?:static[ \t]+)?(?:const\s+)?bool\s+\w+\s*=\s*[01]\s*;" * | wc -l
161

Are you going to submit patches for all of them one at a time?

I suggest sending maybe 10 to 12 patches, one for each subsystem,
and cc the trivial maintainer Jiri Kosina <trivial@kernel.org>
