From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [RESEND PATCH 0/4] Missing QRTR features
Date: Wed,  7 Jun 2017 14:07:35 -0700
Message-ID: <20170607210739.27263-1-bjorn.andersson@linaro.org>
Cc: Arun Kumar Neelakantam <aneela@codeaurora.org>,
        netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        linux-kernel@vger.kernel.org, Courtney Cavin <ccavin@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The QMUX specification covers packet routing as well as service life cycle and
discovery. The current implementation of qrtr supports the prior part, but in
order to fully implement service management on-top a few more parts are needed.

The first patch in the series serves the purpose of reducing duplication in
patch two and three.

The second and third patch adds two qrtr-level notifications required by the
specification, in order to notify local and remote service controllers about
dying clients.

The last patch serves the purpose of notifying local clients about the presence
of a local service register, allowing them to register services as well as
querying for remote registered services.

Bjorn Andersson (4):
  net: qrtr: Refactor packet allocation
  net: qrtr: Inject BYE on remote termination
  net: qrtr: Broadcast DEL_CLIENT message when endpoint is closed
  net: qrtr: Inform open sockets about new controller

 net/qrtr/qrtr.c | 104 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 98 insertions(+), 6 deletions(-)

-- 
2.12.0
