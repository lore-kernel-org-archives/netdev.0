From: Rainer Baumann <baumann@tik.ee.ethz.ch>
Subject: [PATCH 2.6.17.13 1/2] LARTC: trace control for netem: userspace
Date: Sat, 23 Sep 2006 09:04:49 +0200
Message-ID: <4514DC91.2070507@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>, netdev@VGER.KERNEL.ORG,
	netem@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trace Control for Netem: Emulate network properties such as long range dependency and self-similarity of cross-traffic.

user space (iproute2):
The directory tc/netem was split in two parts, one containing the original distribution tables and the other the tools to generate trace files as well as the program responsible for reading the delay values from the trace file and sending them to the kernel (called flowseed).

If the trace option is set, netem initializes the kernel and starts the flowseedprocess. The flowseedprocess does not
send data to the kernel until the registration is completed. The data is sent to the kernel module via configfs. For each qdisc applied, a new directory (in /config/tcn/) is created. The write returns when the kernel needs new data, or when the corresponding qdisc was deleted. In the first case new data is sent and in the latter case the flowseedprocess terminates himself.

Signed-off-by: Rainer Baumann <baumann@tik.ee.ethz.ch>

---

Patch for iproute2-2.6.16-060323: http://tcn.hypert.net/tcn_iproute2.patch


