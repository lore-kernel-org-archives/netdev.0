From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] drivers:net:wireless: Add proper locking for the function,
 b43_op_beacon_set_tim in main.c
Date: Mon, 05 Jan 2015 11:46:40 -0600
Message-ID: <54AACE00.8060407@lwfinger.net>
References: <1420184041-6788-1-git-send-email-xerofoify@gmail.com> <87tx05378x.fsf@kamboji.qca.qualcomm.com> <54AAC6EE.2000603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	b43-dev@lists.infradead.org, stefano.brivio@polimi.it,
	linux-kernel@vger.kernel.org
To: nick <xerofoify@gmail.com>, Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54AAC6EE.2000603@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/2015 11:16 AM, nick wrote:
> Kalle,
> That's fine. On the other hand I am interested in the
> reasons why this patch was dropped so I can send in a
> version 2 of this patch.
> Regards Nick

Apparently you missed Michael B=FCsch's comment:

"Thanks for the patch.

However, this does not work. We are in atomic context here.
Please see the b43-dev mailing list archives for a recent thread about =
that.
I'm also pretty sure that this is safe without lock, due to the higher =
level=20
locks in mac80211."

Did you actually test the patch? If Michael is right, and I trust him o=
n this=20
matter, your patch should lock the system.

Larry
