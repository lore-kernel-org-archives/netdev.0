From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 1/2] net: adding memory barrier to the poll and receive
 callbacks
Date: Mon, 29 Jun 2009 13:20:00 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0906291318460.30244@makko.or.mcafeemobile.com>
References: <20090629140434.GE3845@jolsa.lab.eng.brq.redhat.com> <20090629141445.GF3845@jolsa.lab.eng.brq.redhat.com> <alpine.DEB.1.10.0906290826300.29966@makko.or.mcafeemobile.com> <20090629173217.GC2742@ami.dom.local> <alpine.DEB.1.10.0906291033140.30244@makko.or.mcafeemobile.com>
 <20090629201733.GB3417@jolsa.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, oleg@redhat.com, eric.dumazet@gmail.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755803AbZF2UWB@vger.kernel.org>
In-Reply-To: <20090629201733.GB3417@jolsa.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Jun 2009, Jiri Olsa wrote:

> my thinking was that both variants will endup in the same code anyway,
> so it'd be probably better if the more readable (subjective) got in..
> 
> however I dont have any strong preffering feelings about either of those choices,
> so I can convert easilly :)

Please use the existing poll_wait() then, as there's no reason to add 
another API.


- Davide
