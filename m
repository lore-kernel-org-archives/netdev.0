From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH -next] tcm_vhost: remove unused variable in
	vhost_scsi_allocate_cmd()
Date: Thu, 08 Nov 2012 21:24:41 -0800
Message-ID: <1352438681.29589.514.camel@haakon2.linux-iscsi.org>
References: <CAPgLHd81=dTwwSTgUtd9YbgWf8YLMfi3VJQ-76h71+0W_mx_2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, yongjun_wei@trendmicro.com.cn,
	target-devel <target-devel@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAPgLHd81=dTwwSTgUtd9YbgWf8YLMfi3VJQ-76h71+0W_mx_2g@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hello Wei,

On Wed, 2012-11-07 at 20:53 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The variable se_sess is initialized but never used
> otherwise, so remove the unused variable.
> 
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/vhost/tcm_vhost.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/vhost/tcm_vhost.c b/drivers/vhost/tcm_vhost.c
> index 23c138f..551fff0 100644
> --- a/drivers/vhost/tcm_vhost.c
> +++ b/drivers/vhost/tcm_vhost.c
> @@ -415,14 +415,12 @@ static struct tcm_vhost_cmd *vhost_scsi_allocate_cmd(
>  {
>  	struct tcm_vhost_cmd *tv_cmd;
>  	struct tcm_vhost_nexus *tv_nexus;
> -	struct se_session *se_sess;
>  
>  	tv_nexus = tv_tpg->tpg_nexus;
>  	if (!tv_nexus) {
>  		pr_err("Unable to locate active struct tcm_vhost_nexus\n");
>  		return ERR_PTR(-EIO);
>  	}
> -	se_sess = tv_nexus->tvn_se_sess;
>  
>  	tv_cmd = kzalloc(sizeof(struct tcm_vhost_cmd), GFP_ATOMIC);
>  	if (!tv_cmd) {
> 
> --

Looks fine to me.

Reviewed-by + Acked-by: Nicholas Bellinger <nab@linux-iscsi.org>

Thanks!
