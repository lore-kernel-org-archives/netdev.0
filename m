From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [RFC net-next 1/1] : sctp: denoise deprecation log on SCTP_EVENTS
Date: Thu, 09 Jul 2015 06:38:15 -0400
Message-ID: <559E4F17.9090107@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020808080305050509030007"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:35300 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbbGIKiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 06:38:18 -0400
Received: by igcqs7 with SMTP id qs7so76877421igc.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 03:38:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020808080305050509030007
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit



In the newer kernels this message is extremely noisy. After a quick
discussion with Daniel it seems to me it will be very hard to get
existing apps that nobody is going to update to continue to work
(i.e no forward compat). And newer apps that desire to play in both
older kernels and new kernels will have to play some tricks to work
(i.e weak backward compatibility).  These are good reasons
to totally get rid of this message. At minimal to neutre it.
The attached change tries to do that. However, if you had multiple
apps, you will only get warning for the first one.

Will send proper patch when theres some consensus.

cheers,
jamal

--------------020808080305050509030007
Content-Type: text/plain; charset=us-ascii;
 name="sctp-denoise"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="sctp-denoise"

ZGlmZiAtLWdpdCBhL25ldC9zY3RwL3NvY2tldC5jIGIvbmV0L3NjdHAvc29ja2V0LmMKaW5k
ZXggNWY2YzRlNi4uMGU4YzkzNyAxMDA2NDQKLS0tIGEvbmV0L3NjdHAvc29ja2V0LmMKKysr
IGIvbmV0L3NjdHAvc29ja2V0LmMKQEAgLTIyMDcsOSArMjIwNywxMCBAQCBzdGF0aWMgaW50
IHNjdHBfc2V0c29ja29wdF9ldmVudHMoc3RydWN0IHNvY2sgKnNrLCBjaGFyIF9fdXNlciAq
b3B0dmFsLAogCQlyZXR1cm4gLUVGQVVMVDsKIAogCWlmIChzY3RwX3NrKHNrKS0+c3Vic2Ny
aWJlLnNjdHBfZGF0YV9pb19ldmVudCkKLQkJcHJfd2Fybl9yYXRlbGltaXRlZChERVBSRUNB
VEVEICIlcyAocGlkICVkKSAiCi0JCQkJICAgICJSZXF1ZXN0ZWQgU0NUUF9TTkRSQ1ZJTkZP
IGV2ZW50LlxuIgotCQkJCSAgICAiVXNlIFNDVFBfUkNWSU5GTyB0aHJvdWdoIFNDVFBfUkVD
VlJDVklORk8gb3B0aW9uIGluc3RlYWQuXG4iLAorCQlwcl93YXJuX29uY2UoREVQUkVDQVRF
RCAiJXMgKHBpZCAlZCkgIgorCQkJCSAgICAiU0NUUF9FVkVOVFMgT3B0aW9uIC0gREVQUkVD
QVRFRFxuIgorCQkJCSAgICAiVXNlIFNDVFBfRVZFTlQgT3B0aW9uIGluc3RlYWRcbiIKKwkJ
CQkgICAgIlJlZmVyIHRvIFJGQzY0NTggc2VjdGlvbiA2LjJcbiIsCiAJCQkJICAgIGN1cnJl
bnQtPmNvbW0sIHRhc2tfcGlkX25yKGN1cnJlbnQpKTsKIAogCS8qIEF0IHRoZSB0aW1lIHdo
ZW4gYSB1c2VyIGFwcCBzdWJzY3JpYmVzIHRvIFNDVFBfU0VOREVSX0RSWV9FVkVOVCwK
--------------020808080305050509030007--
