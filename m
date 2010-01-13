From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 1/2] net: tcp_header_len_th and tcp_option_len_th
Date: Wed, 13 Jan 2010 06:03:35 -0500
Message-ID: <4B4DA887.5070309@gmail.com>
References: <4B44FE3C.6060809@gmail.com> <4B450065.4010108@gmail.com> <4B4C519E.2090207@gmail.com> <4B4CB46C.8020502@gmail.com> <4B4CB712.8030806@gmail.com> <4B4D8A24.4070108@gmail.com> <4B4D99B0.8090102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755528Ab0AMLDl@vger.kernel.org>
In-Reply-To: <4B4D99B0.8090102@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
  2) You also should know that sizeof() is *strongly* typed (size_t),
> not an "untyped constant".
> 
My apologies, it's fairly early in the morning here -- I meant
"unsigned" rather than "untyped".


> The (int) cast it not only _not_ needed, its also confusing.
> 
I'm sorry for your confusion.  I believe it adds clarity.

Moreover, it's fairly egregious that the old tcp_hdrlen()
contributor didn't take signed versus unsigned into account.

Perhaps we could move along to more substantive issues....

Have you had an opportunity to test PATCH 2/2 in this series?
