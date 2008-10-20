From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: [PATCH 1/1] [net/irda]: new Blackfin on-chip SIR IrDA driver
Date: Mon, 20 Oct 2008 16:25:57 -0400
Message-ID: <200810201625.58004.rgetz@blackfin.uclinux.org>
References: <1223892294-18683-1-git-send-email-cooloney@kernel.org> <20081019204858.GA3143@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Bryan Wu" <cooloney@kernel.org>, jgarzik@pobox.com,
	irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Graf Yang" <graf.yang@analog.com>
To: "Samuel Ortiz" <samuel@sortiz.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755349AbYJTU0O@vger.kernel.org>
In-Reply-To: <20081019204858.GA3143@sortiz.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun 19 Oct 2008 16:48, Samuel Ortiz pondered:
> Also, I'm surprised you dont have runtime machine id detection. I know
> that's none of my business, but are you guys working towards having 
> one single kernel supporting all blackfin CPUs ?

Nope.

Today we don't support run time processor detection in any of the drivers. 
(Since none of our end users or developers want it -- they ask us for 
smaller/faster, and compile time overhead for multiple products isn't a 
problem)...

I'm not disagreeing that the ifdef uglyness should be worked on - but that is 
separate than run time detection.

-Robin
