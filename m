From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 8/8] staging: et131x: Implement NAPI support
Date: Wed, 20 Aug 2014 20:25:45 -0700
Message-ID: <20140820202545.3a8bafd0@uryu.home.lan>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
	<1408573078-9320-9-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408573078-9320-9-git-send-email-mark.einon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Aug 2014 23:17:58 +0100
Mark Einon <mark.einon@gmail.com> wrote:

> -	bool done = true;
> +	int count = 0;
> +	int limit = budget;
> +	bool not_done = false;

Don't use negative variables. Better to keep the original done variable.
