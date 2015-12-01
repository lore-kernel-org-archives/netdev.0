From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Tue, 01 Dec 2015 07:33:05 -0800
Message-ID: <1448983985.25582.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <y@samsung.com>
	 <1448961223-41888-4-git-send-email-sunil.kovvuri@gmail.com>
	 <01d101d12c46$2de43b40$89acb1c0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Sunil Goutham' <sunil.kovvuri@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	'Sunil Goutham' <sgoutham@cavium.com>
To: Pavel Fedin <p.fedin@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <01d101d12c46$2de43b40$89acb1c0$@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-12-01 at 17:40 +0300, Pavel Fedin wrote:
>  Hello!
> 
>  This one breaks networking on my machine:
> --- cut ---
> swiotlb: coherent allocation failed for device 0002:01:08.4 size=4198400
> CPU: 2 PID: 3655 Comm: NetworkManager Tainted: G        W  O    4.2.6+ #201
> Hardware name: Cavium ThunderX CN88XX

Are you sure 4.2.6 kernel is suitable for backporting this patch aimed
for linux-4.5 ?
