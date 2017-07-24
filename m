From: Stephen Hemminger <stephen@networkplumber.org>
Subject: mlx5 still has lots of warnings
Date: Mon, 24 Jul 2017 09:51:44 -0700
Message-ID: <20170724095144.57f994ad@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:38599 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751521AbdGXQvw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:51:52 -0400
Received: by mail-pg0-f47.google.com with SMTP id s4so59387625pgr.5
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:51:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I sent patches for this, and you said you were going to solve this (back in=
 April).
Still see lots of warnings from MLX5.

  CC [M]  drivers/net/ethernet/mellanox/mlx5/core/en_rep.o
drivers/net/ethernet/mellanox/mlx5/core/en_rep.c:767:35: warning: =E2=80=98=
mlx5e_rep_switchdev_ops=E2=80=99 defined but not used [-Wunused-const-varia=
ble=3D]
 static const struct switchdev_ops mlx5e_rep_switchdev_ops =3D {
                                   ^~~~~~~~~~~~~~~~~~~~~~~
In file included from drivers/net/ethernet/mellanox/mlx5/core/en_rep.c:41:0:
drivers/net/ethernet/mellanox/mlx5/core/en.h:188:19: warning: =E2=80=98mlx5=
e_priv_flags=E2=80=99 defined but not used [-Wunused-const-variable=3D]
 static const char mlx5e_priv_flags[][ETH_GSTRING_LEN] =3D {
                   ^~~~~~~~~~~~~~~~
In file included from drivers/net/ethernet/mellanox/mlx5/core/en.h:51:0,
                 from drivers/net/ethernet/mellanox/mlx5/core/en_rep.c:41:
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:427:34: warning: =E2=80=
=98mlx5e_pme_error_desc=E2=80=99 defined but not used [-Wunused-const-varia=
ble=3D]
 static const struct counter_desc mlx5e_pme_error_desc[] =3D {
                                  ^~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:423:34: warning: =E2=80=
=98mlx5e_pme_status_desc=E2=80=99 defined but not used [-Wunused-const-vari=
able=3D]
 static const struct counter_desc mlx5e_pme_status_desc[] =3D {
                                  ^~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:372:34: warning: =E2=80=
=98sq_stats_desc=E2=80=99 defined but not used [-Wunused-const-variable=3D]
 static const struct counter_desc sq_stats_desc[] =3D {
                                  ^~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:331:34: warning: =E2=80=
=98rq_stats_desc=E2=80=99 defined but not used [-Wunused-const-variable=3D]
 static const struct counter_desc rq_stats_desc[] =3D {
                                  ^~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:303:34: warning: =E2=80=
=98pcie_perf_stats_desc=E2=80=99 defined but not used [-Wunused-const-varia=
ble=3D]
 static const struct counter_desc pcie_perf_stats_desc[] =3D {
                                  ^~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:284:34: warning: =E2=80=
=98pport_per_prio_pfc_stats_desc=E2=80=99 defined but not used [-Wunused-co=
nst-variable=3D]
 static const struct counter_desc pport_per_prio_pfc_stats_desc[] =3D {
                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:277:34: warning: =E2=80=
=98pport_per_prio_traffic_stats_desc=E2=80=99 defined but not used [-Wunuse=
d-const-variable=3D]
 static const struct counter_desc pport_per_prio_traffic_stats_desc[] =3D {
                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:272:34: warning: =E2=80=
=98pport_phy_statistical_stats_desc=E2=80=99 defined but not used [-Wunused=
-const-variable=3D]
 static const struct counter_desc pport_phy_statistical_stats_desc[] =3D {
                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:256:34: warning: =E2=80=
=98pport_2819_stats_desc=E2=80=99 defined but not used [-Wunused-const-vari=
able=3D]
 static const struct counter_desc pport_2819_stats_desc[] =3D {
                                  ^~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:250:34: warning: =E2=80=
=98pport_2863_stats_desc=E2=80=99 defined but not used [-Wunused-const-vari=
able=3D]
 static const struct counter_desc pport_2863_stats_desc[] =3D {
                                  ^~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:229:34: warning: =E2=80=
=98pport_802_3_stats_desc=E2=80=99 defined but not used [-Wunused-const-var=
iable=3D]
 static const struct counter_desc pport_802_3_stats_desc[] =3D {
                                  ^~~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:145:34: warning: =E2=80=
=98vport_stats_desc=E2=80=99 defined but not used [-Wunused-const-variable=
=3D]
 static const struct counter_desc vport_stats_desc[] =3D {
                                  ^~~~~~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:133:34: warning: =E2=80=
=98q_stats_desc=E2=80=99 defined but not used [-Wunused-const-variable=3D]
 static const struct counter_desc q_stats_desc[] =3D {
                                  ^~~~~~~~~~~~
drivers/net/ethernet/mellanox/mlx5/core/en_stats.h:92:34: warning: =E2=80=
=98sw_stats_desc=E2=80=99 defined but not used [-Wunused-const-variable=3D]
 static const struct counter_desc sw_stats_desc[] =3D {
                                  ^~~~~~~~~~~~~
  LD [M]  drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.o
