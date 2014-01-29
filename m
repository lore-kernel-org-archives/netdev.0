From: Fernando Gont <fernando@gont.com.ar>
Subject: Fwd: RFC 7112 on Implications of Oversized IPv6 Header Chains
Date: Wed, 29 Jan 2014 16:25:23 -0300
Message-ID: <52E955A3.7080408@gont.com.ar>
References: <20140129173044.D475C7FC17B@rfc-editor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:33422 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbaA2Tu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 14:50:26 -0500
In-Reply-To: <20140129173044.D475C7FC17B@rfc-editor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

FYI. This one has important implications -- it allows stateless
filtering in IPv6 (otherwise not really possible)



-------- Original Message --------
Subject: RFC 7112 on Implications of Oversized IPv6 Header Chains
Date: Wed, 29 Jan 2014 09:30:44 -0800 (PST)
From: rfc-editor@rfc-editor.org
To: ietf-announce@ietf.org, rfc-dist@rfc-editor.org
CC: drafts-update-ref@iana.org, ipv6@ietf.org, rfc-editor@rfc-editor.org

A new Request for Comments is now available in online RFC libraries.


        RFC 7112

        Title:      Implications of Oversized IPv6 Header
                    Chains
        Author:     F. Gont, V. Manral,
                    R. Bonica
        Status:     Standards Track
        Stream:     IETF
        Date:       January 2014
        Mailbox:    fgont@si6networks.com,
                    vishwas@ionosnetworks.com,
                    rbonica@juniper.net
        Pages:      8
        Characters: 15897
        Updates:    RFC 2460

        I-D Tag:    draft-ietf-6man-oversized-header-chain-09.txt

        URL:        http://www.rfc-editor.org/rfc/rfc7112.txt

The IPv6 specification allows IPv6 Header Chains of an arbitrary
size.  The specification also allows options that can, in turn,
extend each of the headers.  In those scenarios in which the IPv6
Header Chain or options are unusually long and packets are
fragmented, or scenarios in which the fragment size is very small,
the First Fragment of a packet may fail to include the entire IPv6
Header Chain.  This document discusses the interoperability and
security problems of such traffic, and updates RFC 2460 such that the
First Fragment of a packet is required to contain the entire IPv6
Header Chain.

This document is a product of the IPv6 Maintenance Working Group of the
IETF.

This is now a Proposed Standard.

STANDARDS TRACK: This document specifies an Internet standards track
protocol for the Internet community,and requests discussion and suggestions
for improvements.  Please refer to the current edition of the Internet
Official Protocol Standards (STD 1) for the standardization state and
status of this protocol.  Distribution of this memo is unlimited.

This announcement is sent to the IETF-Announce and rfc-dist lists.
To subscribe or unsubscribe, see
  http://www.ietf.org/mailman/listinfo/ietf-announce
  http://mailman.rfc-editor.org/mailman/listinfo/rfc-dist

For searching the RFC series, see
http://www.rfc-editor.org/search/rfc_search.php
For downloading RFCs, see http://www.rfc-editor.org/rfc.html

Requests for special distribution should be addressed to either the
author of the RFC in question, or to rfc-editor@rfc-editor.org.  Unless
specifically noted otherwise on the RFC itself, all RFCs are for
unlimited distribution.


The RFC Editor Team
Association Management Solutions, LLC


--------------------------------------------------------------------
IETF IPv6 working group mailing list
ipv6@ietf.org
Administrative Requests: https://www.ietf.org/mailman/listinfo/ipv6
--------------------------------------------------------------------




-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
