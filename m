From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH v2] net: wireless: rtlwifi: rtl8192cu: hw.c:  Cleaning up if statement that always evaluates to false
Date: Sat, 21 Jun 2014 23:00:36 +0200
Message-ID: <1403384437-9615-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Peter Wu <lekensteyn@gmail.com>,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I found a logical error in an if statement that always evaluates to false.

This has after same discussion resulted in that we add a macro to handle this.

This was partly found using a static code analysis program called cppcheck.

Rickard Strandqvist (1):
  net: wireless: rtlwifi: rtl8192cu: hw.c:  Cleaning up if statement that always evaluates to false

 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h |    1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c  |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

-- 
1.7.10.4
