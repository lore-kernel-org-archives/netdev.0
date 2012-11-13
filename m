From: Srinivas KANDAGATLA <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
Subject: [RFC PATCH v1 3.7.0-rc4 0/2] dt:net/stmmac add full device tree
 support
Date: Tue, 13 Nov 2012 13:50:07 +0000
Message-ID: <1352814607-13788-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>

This patch series attempts to add full device tree support to stmmac driver.
Existing device bindings do not cover all the possible use cases of stmmac driver,
so new properties are added.

And also stmmac phy reset callback support via devicetrees is added.

Srinivas Kandagatla (2):
  dt:net/stmmac: Add complete device tree support
  dt:net/stmmac: Add dt specific phy reset callback support.

 Documentation/devicetree/bindings/net/stmmac.txt   |   51 +++++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   50 ++++++++++++++---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   58 ++++++++++++++------
 3 files changed, 131 insertions(+), 28 deletions(-)
