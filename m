From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 0/4] Add bnx2 iscsi support.
Date: Fri, 1 May 2009 13:00:35 -0700
Message-ID: <1241208039-6813-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: davem@davemloft.net, michaelc@cs.wisc.edu,
	James.Bottomley@HansenPartnership.com
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Adding linux-scsi and James to CC, please review.  David
has ACK'ed the networking portion.  We have also fixed up
some sparse warnings.  The iscsi patches require these 2
patches from the iscsi tree:

    libiscsi: export iscsi_itt_to_task for bnx2i
    iscsi: pass ep connect shost


