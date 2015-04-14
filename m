From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Tue, 14 Apr 2015 07:21:41 -0700
Message-ID: <1429021301.7346.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com>
	 <1429017572.7346.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552D1CD7.7040705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <552D1CD7.7040705@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-04-14 at 15:57 +0200, Denys Vlasenko wrote:

> My allyesconfig, with BUG_ON's commented out:
> 

Right. But I can tell you nobody uses lockdep on a production kernel.

Here, at Google, we get what I described.
