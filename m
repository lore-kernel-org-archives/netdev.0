From: "Boyer, Andrew" <Andrew.Boyer@dell.com>
Subject: Re: [PATCH] net/mlx4: fix spelling mistake: "availible" ->
 "available"
Date: Wed, 16 Aug 2017 13:27:09 +0000
Message-ID: <D5B9C03F.1D2C0%Andrew.Boyer@emc.com>
References: <20170816090511.10463-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170816090511.10463-1-colin.king@canonical.com>
Content-Language: en-US
Content-ID: <BB1C4C8206975049BB4773B61D7D2E05@mail.corp.emc.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 8/16/17, 5:05 AM, "linux-rdma-owner@vger.kernel.org on behalf of Colin
King" <linux-rdma-owner@vger.kernel.org on behalf of
colin.king@canonical.com> wrote:

>From: Colin Ian King <colin.king@canonical.com>
>
>Trivial fix to spelling mistakes in the mlx4 driver
>
>Signed-off-by: Colin Ian King <colin.king@canonical.com>
>---
> drivers/net/ethernet/mellanox/mlx4/cmd.c    | 16 ++++++++--------
> drivers/net/ethernet/mellanox/mlx4/fw_qos.c |  6 +++---
> drivers/net/ethernet/mellanox/mlx4/fw_qos.h | 10 +++++-----
> 3 files changed, 16 insertions(+), 16 deletions(-)
>
>diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c
>b/drivers/net/ethernet/mellanox/mlx4/cmd.c
>index 674773b28b2e..6309389b09a7 100644
>--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
>+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
>@@ -1958,19 +1958,19 @@ static void mlx4_allocate_port_vpps(struct
>mlx4_dev *dev, int port)
> 	int i;
> 	int err;
> 	int num_vfs;
>-	u16 availible_vpp;
>+	u16 available_vpp;
> 	u8 vpp_param[MLX4_NUM_UP];
> 	struct mlx4_qos_manager *port_qos;
> 	struct mlx4_priv *priv =3D mlx4_priv(dev);
>=20
>-	err =3D mlx4_ALLOCATE_VPP_get(dev, port, &availible_vpp, vpp_param);
>+	err =3D mlx4_ALLOCATE_VPP_get(dev, port, &available_vpp, vpp_param);
> 	if (err) {
>-		mlx4_info(dev, "Failed query availible VPPs\n");
>+		mlx4_info(dev, "Failed query available VPPs\n");
> 		return;
> 	}
>=20
> 	port_qos =3D &priv->mfunc.master.qos_ctl[port];
>-	num_vfs =3D (availible_vpp /
>+	num_vfs =3D (available_vpp /
> 		   bitmap_weight(port_qos->priority_bm, MLX4_NUM_UP));
>=20
> 	for (i =3D 0; i < MLX4_NUM_UP; i++) {
>@@ -1985,14 +1985,14 @@ static void mlx4_allocate_port_vpps(struct
>mlx4_dev *dev, int port)
> 	}
>=20
> 	/* Query actual allocated VPP, just to make sure */
>-	err =3D mlx4_ALLOCATE_VPP_get(dev, port, &availible_vpp, vpp_param);
>+	err =3D mlx4_ALLOCATE_VPP_get(dev, port, &available_vpp, vpp_param);
> 	if (err) {
>-		mlx4_info(dev, "Failed query availible VPPs\n");
>+		mlx4_info(dev, "Failed query available VPPs\n");
> 		return;
> 	}
>=20
> 	port_qos->num_of_qos_vfs =3D num_vfs;
>-	mlx4_dbg(dev, "Port %d Availible VPPs %d\n", port, availible_vpp);
>+	mlx4_dbg(dev, "Port %d Availible VPPs %d\n", port, available_vpp);

One more here, in the text.          ^^^

>=20
> 	for (i =3D 0; i < MLX4_NUM_UP; i++)
> 		mlx4_dbg(dev, "Port %d UP %d Allocated %d VPPs\n", port, i,
>@@ -2891,7 +2891,7 @@ static int mlx4_set_vport_qos(struct mlx4_priv
>*priv, int slave, int port,
> 	memset(vpp_qos, 0, sizeof(struct mlx4_vport_qos_param) * MLX4_NUM_UP);
>=20
> 	if (slave > port_qos->num_of_qos_vfs) {
>-		mlx4_info(dev, "No availible VPP resources for this VF\n");
>+		mlx4_info(dev, "No available VPP resources for this VF\n");
> 		return -EINVAL;
> 	}
>=20
>diff --git a/drivers/net/ethernet/mellanox/mlx4/fw_qos.c
>b/drivers/net/ethernet/mellanox/mlx4/fw_qos.c
>index 8f2fde0487c4..3a09d7122d3b 100644
>--- a/drivers/net/ethernet/mellanox/mlx4/fw_qos.c
>+++ b/drivers/net/ethernet/mellanox/mlx4/fw_qos.c
>@@ -65,7 +65,7 @@ struct mlx4_set_port_scheduler_context {
>=20
> /* Granular Qos (per VF) section */
> struct mlx4_alloc_vpp_param {
>-	__be32 availible_vpp;
>+	__be32 available_vpp;
> 	__be32 vpp_p_up[MLX4_NUM_UP];
> };
>=20
>@@ -157,7 +157,7 @@ int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8
>port, u8 *tc_tx_bw,
> EXPORT_SYMBOL(mlx4_SET_PORT_SCHEDULER);
>=20
> int mlx4_ALLOCATE_VPP_get(struct mlx4_dev *dev, u8 port,
>-			  u16 *availible_vpp, u8 *vpp_p_up)
>+			  u16 *available_vpp, u8 *vpp_p_up)
> {
> 	int i;
> 	int err;
>@@ -179,7 +179,7 @@ int mlx4_ALLOCATE_VPP_get(struct mlx4_dev *dev, u8
>port,
> 		goto out;
>=20
> 	/* Total number of supported VPPs */
>-	*availible_vpp =3D (u16)be32_to_cpu(out_param->availible_vpp);
>+	*available_vpp =3D (u16)be32_to_cpu(out_param->available_vpp);
>=20
> 	for (i =3D 0; i < MLX4_NUM_UP; i++)
> 		vpp_p_up[i] =3D (u8)be32_to_cpu(out_param->vpp_p_up[i]);
>diff --git a/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
>b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
>index ac1f331878e6..582997577a04 100644
>--- a/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
>+++ b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
>@@ -84,23 +84,23 @@ int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8
>port, u8 *prio2tc);
> int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
> 			    u8 *pg, u16 *ratelimit);
> /**
>- * mlx4_ALLOCATE_VPP_get - Query port VPP availible resources and
>allocation.
>- * Before distribution of VPPs to priorities, only availible_vpp is
>returned.
>+ * mlx4_ALLOCATE_VPP_get - Query port VPP available resources and
>allocation.
>+ * Before distribution of VPPs to priorities, only available_vpp is
>returned.
>  * After initialization it returns the distribution of VPPs among
>priorities.
>  *
>  * @dev: mlx4_dev.
>  * @port: Physical port number.
>- * @availible_vpp: Pointer to variable where number of availible VPPs is
>stored
>+ * @available_vpp: Pointer to variable where number of available VPPs is
>stored
>  * @vpp_p_up: Distribution of VPPs to priorities is stored in this array
>  *
>  * Returns 0 on success or a negative mlx4_core errno code.
>  **/
> int mlx4_ALLOCATE_VPP_get(struct mlx4_dev *dev, u8 port,
>-			  u16 *availible_vpp, u8 *vpp_p_up);
>+			  u16 *available_vpp, u8 *vpp_p_up);
> /**
>  * mlx4_ALLOCATE_VPP_set - Distribution of VPPs among differnt
>priorities.
>  * The total number of VPPs assigned to all for a port must not exceed
>- * the value reported by availible_vpp in mlx4_ALLOCATE_VPP_get.
>+ * the value reported by available_vpp in mlx4_ALLOCATE_VPP_get.
>  * VPP allocation is allowed only after the port type has been set,
>  * and while no QPs are open for this port.
>  *
>--=20
>2.11.0
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
