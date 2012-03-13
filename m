From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 v3] netxen: qlogic ethernet : Fix endian bug.
Date: Tue, 13 Mar 2012 01:04:06 -0700 (PDT)
Message-ID: <20120313.010406.769202674785007195.davem@davemloft.net>
References: <1331624093-12598-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: santoshprasadnayak@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331624093-12598-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


You didn't even compile test this.

> -	if (*mac == cpu_to_le64(~0ULL)) {
> +	if (*mac == ~0ULL)) {

This is unacceptable, I'm ignoring you for at least a week.
