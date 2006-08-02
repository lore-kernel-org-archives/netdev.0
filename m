From: Rainer Baumann <baumann@tik.ee.ethz.ch>
Subject: [PATCH 2.6.16.19 1/2] LARTC: trace control for netem: userspace
Date: Wed, 02 Aug 2006 19:21:43 +0200
Message-ID: <44D0DF27.5000403@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>, netdev@VGER.KERNEL.ORG
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trace Control for Netem: Emulate network properties such as
long-dependency and self-similarity of cross-traffic.

The directory tc/netem was split in two parts, one containing the
original distributions and the other the tools to generate trace files
as well as the program responsible for reading the delay values from the
trace file and sending them to the kernel (called flowseed).
If the trace option is set, netem starts the flowseedprocess and
initializes the kernel. To be able to kill the flowseedprocess, in case
the command was faulty, the PID of the flowseedprocess is passed to the
netem kernel module. If the kernel receives packet delay data from a not
registered PID, the Process will be killed. The flowseedprocess does not
send data to the kernel until the registration is completed.

Signed-off-by: Rainer Baumann <baumann@tik.ee.ethz.ch>

---

Patch for iproute2-2.6.16-060323: http://tcn.hypert.net/tcnIproute.patch



