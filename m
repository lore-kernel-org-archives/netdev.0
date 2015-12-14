From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Information leak in pptp_bind
Date: Mon, 14 Dec 2015 23:44:53 +0100
Message-ID: <566F4665.6070800@stressinduktion.org>
References: <CAEeQi3u5VDmmaLGHAzG1NOknXo=Ap0MdXZiYPusEX3VSx8R3Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: syzkaller@googlegroups.com, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>, edumazet@google.com,
	Sasha Levin <sasha.levin@oracle.com>, keescook@google.com,
	jln@google.com
To: Dmitry Vyukov <dvyukov@gmail.com>, Dmitry Kozlov <xeb@mail.ru>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEeQi3u5VDmmaLGHAzG1NOknXo=Ap0MdXZiYPusEX3VSx8R3Jw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14.12.2015 11:38, Dmitry Vyukov wrote:
> The following program leak various uninit garbage including kernel
> addresses and whatever is on kernel stack, in particular defeating
> ASLR. The issue is in pptp_bind which does not verify sockaddr_len.

Thanks for the report!

I send out a patch soon.
