From: Rick Jones <rick.jones2@hp.com>
Subject: Re: A call to revise sockets behaviour
Date: Mon, 29 Jul 2013 10:26:58 -0700
Message-ID: <51F6A5E2.5050100@hp.com>
References: <2066879158.39771.1375110634453.JavaMail.mail@webmail09><20130729083519.5d574f16@nehalam.linuxnetplumber.net> <2063167407.40450.1375112877907.JavaMail.mail@webmail09>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2063167407.40450.1375112877907.JavaMail.mail@webmail09>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> A wine developer clearly showed that this option simply doesn't work.
>
> http://bugs.winehq.org/show_bug.cgi?id=26031#c21
>
> Output of strace:
> getsockopt(24, SOL_SOCKET, SO_REUSEADDR, [0], [4]) = 0
> setsockopt(24, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> bind(24, {sa_family=AF_INET, sin_port=htons(43012), sin_addr=inet_addr("0.
> 0.0.0")}, 16) = -1 EADDRINUSE (Address already in use)

The output of netstat -an didn't by any chance happen to still show an 
endpoint in the LISTEN state for that port number did it?

rick jones
