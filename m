From: Eamonn Hamilton <EAMONN.HAMILTON@saic.com>
Subject: Re: linux 2.6.9: r8169: eth0: PCI error (status: 0x8404). Device
	disabled.
Date: Fri, 22 Oct 2004 10:31:32 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098437493.5513.8.camel@ukabzc383.uk.saic.com>
References: <1098269117.6631.5.camel@ukabzc383.uk.saic.com>
	 <20041020121520.GA4004@electric-eye.fr.zoreil.com>
	 <1098282567.6631.10.camel@ukabzc383.uk.saic.com>
	 <20041020201010.GA13023@electric-eye.fr.zoreil.com>
	 <1098350743.15528.40.camel@ukabzc383.uk.saic.com>
	 <20041021120208.GA752@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041021120208.GA752@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Francois,

Testing 2.6.9 with just the untouched patch applied again fails :

PCI error (cmd = 0x0017, status = 0x22b0)

Testing the kernel with the error reset disabled just causes networking
to stop, with no reported error after copying data from the box for a
bit ( < 1GB )

Tests were tried under 2.6.7 and 2.6.8, but the guy doing the testing
reported odd problems under these kernels ( they were the pre-packaged
debian ones, I'll run up a manual set today sometime ).

Hope this helps,
Eamonn
