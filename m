From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: switchdev: don't abort unsupported operations
Date: Sat, 11 Jul 2015 11:55:51 +0200
Message-ID: <20150711095551.GA2059@nanopsycho.orion>
References: <1436572138-16542-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436572138-16542-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sat, Jul 11, 2015 at 01:48:58AM CEST, vivien.didelot@savoirfairelinux.com wrote:
>There is no need to abort attribute setting or object addition, if the
>prepare phase returned operation not supported.
>
>Thus, abort these two transactions only if the error is not -EOPNOTSUPP.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Sounds reasonable.

Acked-by: Jiri Pirko <jiri@resnulli.us>
