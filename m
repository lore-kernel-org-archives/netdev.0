From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netprio_cgroup: explicitly init the early_init field
Date: Tue, 22 Apr 2014 12:13:15 -0400 (EDT)
Message-ID: <20140422.121315.929124038777369470.davem@davemloft.net>
References: <1398144722-9864-1-git-send-email-nasa4836@gmail.com>
	<20140422111906.GD17116@hmsreliant.think-freely.org>
	<CAHz2CGWfwx+SOTurpW2fO4LsB08tp2ANw+k6aa6bGL=15LNScQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, tj@kernel.org, daniel.wagner@bmw-carit.de,
	gaofeng@cn.fujitsu.com, stephen@networkplumber.org,
	jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nasa4836@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHz2CGWfwx+SOTurpW2fO4LsB08tp2ANw+k6aa6bGL=15LNScQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jianyu Zhan <nasa4836@gmail.com>
Date: Tue, 22 Apr 2014 19:25:41 +0800

> I don't think that the value of one field(early_init) has a so subtle
> restrition on the another field(css_alloc) is a good thing, but since
> it is there, docment it should be needed.

This is not a reasonable change.

We depend upon implicit initialization to zero all over the kernel,
and adding explicit assignments hurts rather then helps.
