From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [KJ] Re: [PATCH 6/28] net/e1000_osdep: replace schedule_timeout()
	with msleep()
Date: Fri, 7 Jan 2005 13:37:44 -0800
Message-ID: <20050107213744.GE2924@us.ibm.com>
References: <20050107001931.GH3055@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============94234515700612187=="
Cc: linux-net@vger.kernel.org, kernel-janitors@lists.osdl.org,
   netdev@oss.sgi.com
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: cramerj@intel.com, john.ronciak@intel.com, ganesh.venkatesan@intel.com
In-Reply-To: <20050107001931.GH3055@us.ibm.com>
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

--===============94234515700612187==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jan 06, 2005 at 04:19:31PM -0800, Nishanth Aravamudan wrote:
> Hi,
> 
> Description: Use msleep() instead of schedule_timeout() to guarantee the task
> delays as expected.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> 
> --- 2.6.10-v/drivers/net/e1000/e1000_osdep.h	2004-12-24 13:34:26.000000000 -0800
> +++ 2.6.10/drivers/net/e1000/e1000_osdep.h	2005-01-04 14:57:49.000000000 -0800
> @@ -46,8 +46,7 @@
>  				/* Don't mdelay in interrupt context! */ \
>  	                	BUG(); \
>  			} else { \
> -				set_current_state(TASK_UNINTERRUPTIBLE); \
> -				schedule_timeout((x * HZ)/1000 + 2); \
> +				msleep(x);
>  			} } while(0)
>  /* Some workarounds require millisecond delays and are run during interrupt
>   * context.  Most notably, when establishing link, the phy may need tweaking

Please ignore this patch, as there is already a more correct one in the
2.6.10-kj patchset. Sorry for the noise.

Thanks,
Nish

--===============94234515700612187==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============94234515700612187==--
