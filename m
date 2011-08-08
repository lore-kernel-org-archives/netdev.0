From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] dp83640: increase receive time stamp
	buffer size
Date: Sun, 07 Aug 2011 22:53:37 -0700 (PDT)
Message-ID: <20110807.225337.661560107256045057.davem@davemloft.net>
References: <cover.1312699693.git.richard.cochran@omicron.at>
	<cover.1312699693.git.richard.cochran@omicron.at>
	<d38d5b44e8894387852a116492cb825159b5842c.1312699694.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, stable@kernel.org
To: richardcochran@gmail.com
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <d38d5b44e8894387852a116492cb825159b5842c.1312699694.git.richard.cochran@omicron.at>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Sun,  7 Aug 2011 09:03:04 +0200

> The dp83640 buffers receive time stamps from special PHY status frames,
> matching them to received PTP packets in a work queue. Because the timeout
> for orphaned time stamps is so long and the buffer is so small, the driver
> can drop time stamps under moderate PTP traffic.
> 
> This commit fixes the issue by decreasing the timeout to (at least) one
> timer tick and increasing the buffer size.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> Cc: <stable@kernel.org>

Applied.

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
