From: "David S. Miller" <davem@davemloft.net>
Subject: [KJ] Re: [PATCH 20/39] net/ip_vs_sync: replace schedule_timeout()
 with ssleep()
Date: Tue, 8 Feb 2005 20:35:49 -0800
Message-ID: <20050208203549.4ede783b.davem@davemloft.net>
References: <20050120235634.GI2600@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============73646059032404754=="
Cc: jmorris@redhat.com, netdev@oss.sgi.com, kaber@coreworks.de,
   yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru,
   kernel-janitors@lists.osdl.org
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20050120235634.GI2600@us.ibm.com>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============73646059032404754==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Thu, 20 Jan 2005 15:56:34 -0800
Nishanth Aravamudan <nacc@us.ibm.com> wrote:

> Please consider applying.
> 
> Description: Use ssleep() instead of schedule_timeout() to guarantee the task
> delays as expected. The first two replacements use TASK_INTERRUPTIBLE but do not
> check for signals, so ssleep() should be appropriate.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

Applied, thanks Nishanth.

--===============73646059032404754==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============73646059032404754==--
