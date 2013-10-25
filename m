From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 1/3] vxlan: silence one build warning
Date: Fri, 25 Oct 2013 15:49:18 +0800
Message-ID: <1382687360-27794-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

drivers/net/vxlan.c: In function =E2=80=98vxlan_sock_add=E2=80=99:
drivers/net/vxlan.c:2298:11: warning: =E2=80=98sock=E2=80=99 may be use=
d uninitialized in this function [-Wmaybe-uninitialized]
drivers/net/vxlan.c:2275:17: note: =E2=80=98sock=E2=80=99 was declared =
here
  LD      drivers/net/built-in.o

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2ef5b62..e15f1af 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2272,7 +2272,7 @@ static struct vxlan_sock *vxlan_socket_create(str=
uct net *net, __be16 port,
 {
 	struct vxlan_net *vn =3D net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
-	struct socket *sock;
+	struct socket *sock =3D NULL;
 	struct sock *sk;
 	int rc =3D 0;
 	unsigned int h;
--=20
1.7.11.7
