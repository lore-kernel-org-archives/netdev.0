From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/1] sctp: not send SCTP_PEER_ADDR_CHANGE notifications
 with failed probe
Date: Thu, 21 Aug 2014 10:47:38 +0200
Message-ID: <53F5B22A.5010307@redhat.com>
References: <1408527103-22772-1-git-send-email-Yanjun.Zhu@windriver.com> <1408527103-22772-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	vyasevich@gmail.com, tuexen@fh-muenster.de,
	khandelwal.deepak.1987@gmail.com, Yue.Tao@windriver.com,
	alexandre.dietsch@windriver.com, davem@davemloft.net,
	Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: Zhu Yanjun <zyjzyj2000@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408527103-22772-2-git-send-email-Yanjun.Zhu@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/20/2014 11:31 AM, Zhu Yanjun wrote:
> Since the transport has always been in state SCTP_UNCONFIRMED, it
> therefore wasn't active before and hasn't been used before, and it
> always has been, so it is unnecessary to bug the user with a
> notification.
>
> Reported-by: Deepak Khandelwal <khandelwal.deepak.1987@gmail.com>
> Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
> Suggested-by: Michael Tuexen <tuexen@fh-muenster.de>
> Suggested-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>

Looks a bit better, thanks!

Acked-by: Daniel Borkmann <dborkman@redhat.com>
