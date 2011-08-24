From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: slow performance on disk/network i/o full speed after drop_caches
Date: Wed, 24 Aug 2011 11:01:03 +0200
Message-ID: <4E54BDCF.9020504@profihost.ag>
References: <4E5494D4.1050605@profihost.ag> <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>,
 Wu Fengguang <fengguang.wu@intel.com>,
 Linux Netdev List <netdev@vger.kernel.org>
To: Pekka Enberg <penberg@kernel.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


>> sync&&  echo 3>/proc/sys/vm/drop_caches&&  sleep 2&&  echo 0
>>> /proc/sys/vm/drop_caches

Another way to get it working again is to stop some processes. Could be 
mysql or apache or php fcgi doesn't matter. Just free some memory. 
Although there are already 5GB free.

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
