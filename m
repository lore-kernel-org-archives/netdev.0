From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: mlx5 still has lots of warnings
Date: Wed, 26 Jul 2017 14:27:16 +0300
Message-ID: <CALzJLG8CK3Vr53Fh5+J14U86g_jTfJU+KgTRHVO4VdATbcdScQ@mail.gmail.com>
References: <20170724095144.57f994ad@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:35211 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdGZL1i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 07:27:38 -0400
Received: by mail-qk0-f169.google.com with SMTP id d145so77466525qkc.2
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 04:27:37 -0700 (PDT)
In-Reply-To: <20170724095144.57f994ad@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 7:51 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> I sent patches for this, and you said you were going to solve this (back =
in April).
> Still see lots of warnings from MLX5.
>

Hi Stephen,

You are right, we were planning to do some code refactoring to this
area and the priority of this task got reduced.

I will handle this myself, I will take your original patch if required.

Thanks for the reminder.

>   CC [M]  drivers/net/ethernet/mellanox/mlx5/core/en_rep.o
> drivers/net/ethernet/mellanox/mlx5/core/en_rep.c:767:35: warning: =E2=80=
=98mlx5e_rep_switchdev_ops=E2=80=99 defined but not used [-Wunused-const-va=
riable=3D]
>  static const struct switchdev_ops mlx5e_rep_switchdev_ops =3D {
>                                    ^~~~~~~~~~~~~~~~~~~~~~~
> In file included from drivers/net/ethernet/mellanox/mlx5/core/en_rep.c:41=
:0:
> drivers/net/ethernet/mellanox/mlx5/core/en.h:188:19: warning: =E2=80=98ml=
x5e_priv_flags=E2=80=99 defined but not used [-Wunused-const-variable=3D]
>  static const char mlx5e_priv_flags[][ETH_GSTRING_LEN] =3D {
>                    ^~~~~~~~~~~~~~~~
> In file included from drivers/net/ethernet/mellanox/mlx5/core/en.h:51:0,
>                  from drivers/net/ethernet/mellanox/mlx5/core/en_rep.c:41=
:
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:427:34: warning: =E2=
=80=98mlx5e_pme_error_desc=E2=80=99 defined but not used [-Wunused-const-va=
riable=3D]
>  static const struct counter_desc mlx5e_pme_error_desc[] =3D {
>                                   ^~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:423:34: warning: =E2=
=80=98mlx5e_pme_status_desc=E2=80=99 defined but not used [-Wunused-const-v=
ariable=3D]
>  static const struct counter_desc mlx5e_pme_status_desc[] =3D {
>                                   ^~~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:372:34: warning: =E2=
=80=98sq_stats_desc=E2=80=99 defined but not used [-Wunused-const-variable=
=3D]
>  static const struct counter_desc sq_stats_desc[] =3D {
>                                   ^~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:331:34: warning: =E2=
=80=98rq_stats_desc=E2=80=99 defined but not used [-Wunused-const-variable=
=3D]
>  static const struct counter_desc rq_stats_desc[] =3D {
>                                   ^~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:303:34: warning: =E2=
=80=98pcie_perf_stats_desc=E2=80=99 defined but not used [-Wunused-const-va=
riable=3D]
>  static const struct counter_desc pcie_perf_stats_desc[] =3D {
>                                   ^~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:284:34: warning: =E2=
=80=98pport_per_prio_pfc_stats_desc=E2=80=99 defined but not used [-Wunused=
-const-variable=3D]
>  static const struct counter_desc pport_per_prio_pfc_stats_desc[] =3D {
>                                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:277:34: warning: =E2=
=80=98pport_per_prio_traffic_stats_desc=E2=80=99 defined but not used [-Wun=
used-const-variable=3D]
>  static const struct counter_desc pport_per_prio_traffic_stats_desc[] =3D=
 {
>                                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:272:34: warning: =E2=
=80=98pport_phy_statistical_stats_desc=E2=80=99 defined but not used [-Wunu=
sed-const-variable=3D]
>  static const struct counter_desc pport_phy_statistical_stats_desc[] =3D =
{
>                                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:256:34: warning: =E2=
=80=98pport_2819_stats_desc=E2=80=99 defined but not used [-Wunused-const-v=
ariable=3D]
>  static const struct counter_desc pport_2819_stats_desc[] =3D {
>                                   ^~~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:250:34: warning: =E2=
=80=98pport_2863_stats_desc=E2=80=99 defined but not used [-Wunused-const-v=
ariable=3D]
>  static const struct counter_desc pport_2863_stats_desc[] =3D {
>                                   ^~~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:229:34: warning: =E2=
=80=98pport_802_3_stats_desc=E2=80=99 defined but not used [-Wunused-const-=
variable=3D]
>  static const struct counter_desc pport_802_3_stats_desc[] =3D {
>                                   ^~~~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:145:34: warning: =E2=
=80=98vport_stats_desc=E2=80=99 defined but not used [-Wunused-const-variab=
le=3D]
>  static const struct counter_desc vport_stats_desc[] =3D {
>                                   ^~~~~~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:133:34: warning: =E2=
=80=98q_stats_desc=E2=80=99 defined but not used [-Wunused-const-variable=
=3D]
>  static const struct counter_desc q_stats_desc[] =3D {
>                                   ^~~~~~~~~~~~
> drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:92:34: warning: =E2=80=
=98sw_stats_desc=E2=80=99 defined but not used [-Wunused-const-variable=3D]
>  static const struct counter_desc sw_stats_desc[] =3D {
>                                   ^~~~~~~~~~~~~
>   LD [M]  drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.o
