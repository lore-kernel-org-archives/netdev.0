From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] drivers:net:wireless: Add proper locking for the function, b43_op_beacon_set_tim in main.c
Date: Mon, 05 Jan 2015 11:29:50 +0200
Message-ID: <87tx05378x.fsf@kamboji.qca.qualcomm.com>
References: <1420184041-6788-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefano.brivio@polimi.it, linux-wireless@vger.kernel.org,
	b43-dev@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420184041-6788-1-git-send-email-xerofoify@gmail.com> (Nicholas
	Krause's message of "Fri, 2 Jan 2015 02:34:01 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicholas Krause <xerofoify@gmail.com> writes:

> This adds proper locking for the function, b43_op_beacon_set_tim in
> main.c by using the mutex lock in the structure pointer wl, as
> embedded into this pointer as a mutex in order to protect against
> multiple access to the pointer wl when updating the templates for this
> pointer in the function, b43_update_templates internally in the
> function, b43_op_beacon_set_tim.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>

Based on the discussion I have dropped this patch.

-- 
Kalle Valo
